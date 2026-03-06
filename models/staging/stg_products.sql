-- stg_products.sql
-- Product catalog. Includes category translation PT → EN.

with products as (
    select * from {{ source('olist', 'products') }}
),

translations as (
    select * from {{ source('olist', 'category_translation') }}
),

renamed as (
    select
        p.product_id,

        -- category (translated to English when available)
        coalesce(t.product_category_name_english, p.product_category_name) as product_category,
        p.product_category_name as product_category_pt,

        -- dimensions
        cast(p.product_weight_g       as integer) as weight_g,
        cast(p.product_length_cm      as integer) as length_cm,
        cast(p.product_height_cm      as integer) as height_cm,
        cast(p.product_width_cm       as integer) as width_cm,
        cast(p.product_photos_qty     as integer) as photos_count,
        cast(p.product_description_lenght as integer) as description_length,
        cast(p.product_name_lenght    as integer) as name_length

    from products p
    left join translations t
        on p.product_category_name = t.product_category_name

    where p.product_id is not null
)

select * from renamed
