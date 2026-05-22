{{
    config(
        materialized='incremental',
        unique_key=['Invoice_DW_ID', 'Bill_Seq', 'Bill_Line_Item_Seq', 'Bill_Line_Item_From_Dt'],
        incremental_strategy='merge',
        merge_update_columns=[
            'Bill_Src_ID',
            'Bill_Src_Line_Item_Seq',
            'Bill_Line_Item_Type_Cd',
            'Price_Comp_DW_ID',
            'Bill_Line_Item_Thru_Dt',
            'Bill_Line_Item_Qty',
            'Bill_Line_Item_Amt',
            'Load_Ts',
            'Ses_Load_ID',
            'Delta_Val',
            'Posting_Rlvnt_Ind',
            'Main_Transn_Cd',
            'Sub_Transn_Cd',
            'GL_Acct_Cd',
            'Cost_Ctr_Cd',
            'DCE_Cd',
            'ABM_Cd',
            'Proj_Cd',
            'Task_Cd',
            'Season_Type_Cd',
            'HashValue',
            'ETLModifiedDate',
            'ETLModifiedBatchID'
        ]
    )
}}

with source as (

    select
        Invoice_DW_ID,
        Bill_Seq,
        Bill_Line_Item_Seq,
        Bill_Src_ID,
        Bill_Src_Line_Item_Seq,
        Bill_Line_Item_Type_Cd,
        Price_Comp_DW_ID,
        Bill_Line_Item_From_Dt,
        Bill_Line_Item_Thru_Dt,
        Bill_Line_Item_Qty,
        Bill_Line_Item_Amt,
        Load_Ts,
        Ses_Load_ID,
        Delta_Val,
        Posting_Rlvnt_Ind,
        Main_Transn_Cd,
        Sub_Transn_Cd,
        GL_Acct_Cd,
        Cost_Ctr_Cd,
        DCE_Cd,
        ABM_Cd,
        Proj_Cd,
        Task_Cd,
        Season_Type_Cd,
        0 as IsDeleted,

        -- Hash for change detection (same logic as the stored proc)
        convert(char(40), hashbytes('SHA1',
            isnull(cast(Invoice_DW_ID as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Seq as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Line_Item_Seq as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Src_ID as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Src_Line_Item_Seq as varchar(40)), 'NA') + '|' +
            isnull(Bill_Line_Item_Type_Cd, 'NA') + '|' +
            isnull(cast(Price_Comp_DW_ID as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Line_Item_From_Dt as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Line_Item_Thru_Dt as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Line_Item_Qty as varchar(40)), 'NA') + '|' +
            isnull(cast(Bill_Line_Item_Amt as varchar(40)), 'NA') + '|' +
            isnull(cast(Load_Ts as varchar(40)), 'NA') + '|' +
            isnull(cast(Ses_Load_ID as varchar(40)), 'NA') + '|' +
            isnull(Delta_Val, 'NA') + '|' +
            isnull(cast(Posting_Rlvnt_Ind as varchar(40)), 'NA') + '|' +
            isnull(Main_Transn_Cd, 'NA') + '|' +
            isnull(Sub_Transn_Cd, 'NA') + '|' +
            isnull(GL_Acct_Cd, 'NA') + '|' +
            isnull(Cost_Ctr_Cd, 'NA') + '|' +
            isnull(DCE_Cd, 'NA') + '|' +
            isnull(ABM_Cd, 'NA') + '|' +
            isnull(Proj_Cd, 'NA') + '|' +
            isnull(Task_Cd, 'NA') + '|' +
            isnull(Season_Type_Cd, 'NA')
        ), 2) as HashValue,

        getdate() as ETLModifiedDate,
        {{ var('etl_batch_id', 0) }} as ETLModifiedBatchID

    from {{ source('prestage', 'Bill_Line_Item') }}

)

select
    *,
    {% if is_incremental() %}
        -- Only process rows where hash has changed or row is new
    {% endif %}
    getdate() as ETLCreatedDate,
    {{ var('etl_batch_id', 0) }} as ETLCreatedBatchID
from source

{% if is_incremental() %}
where HashValue not in (
    select HashValue from {{ this }}
    where Invoice_DW_ID in (select Invoice_DW_ID from source)
      and Bill_Seq in (select Bill_Seq from source)
)
   or not exists (
    select 1 from {{ this }} tgt
    where tgt.Invoice_DW_ID = source.Invoice_DW_ID
      and tgt.Bill_Seq = source.Bill_Seq
      and tgt.Bill_Line_Item_Seq = source.Bill_Line_Item_Seq
      and tgt.Bill_Line_Item_From_Dt = source.Bill_Line_Item_From_Dt
)
{% endif %}
