-- stg_payments.sql
-- Payment data. One order can have multiple payment methods/installments.

with source as (
    select * from {{ source('olist', 'payments') }}
),

renamed as (
    select
        order_id,
        payment_sequential,                          -- installment number
        payment_type,                                -- credit_card, boleto, voucher, debit_card
        cast(payment_installments as integer) as installments,
        round(cast(payment_value as decimal(10,2)), 2) as payment_value

    from source
    where order_id is not null
)

select * from renamed
