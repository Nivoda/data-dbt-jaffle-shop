{{ config(alias='order_line_amounts') }}

-- Retargeted to read core.order_line + core.product (not staging) so dependency
-- direction is Staging -> Core -> Logical, never the reverse.
-- NOTE ON NAMING: every current_catalogue_* / current_product_name column here
-- is the CURRENT product record joined onto the order line at transformation
-- time, not a historical at-purchase snapshot -- the seed/source data carries
-- no purchase-time price or name history. The `current_catalogue_` prefix is
-- deliberate and load-bearing: it must never be dropped or renamed to something
-- that could be read as "what was actually charged" (e.g. plain `unit_price` /
-- `line_amount`), because that would misrepresent current catalogue pricing as
-- historical transactional fact. If the source ever captures price/name as of
-- the purchase moment, that should be modelled as a genuinely new
-- at-purchase-snapshot column, not a rename of these.
with order_lines as (
    select * from {{ ref('order_line') }}
),

products as (
    select * from {{ ref('product') }}
)

select
    order_lines.order_line_id,
    order_lines.order_id,
    order_lines.product_id,
    products.product_name as current_product_name,
    order_lines.quantity,
    products.product_price_cents as current_catalogue_unit_price_cents,
    products.product_price as current_catalogue_unit_price,
    order_lines.quantity * products.product_price_cents as current_catalogue_line_value_cents,
    order_lines.quantity * products.product_price as current_catalogue_line_value,
    order_lines.source_record_id,
    order_lines.source_ingested_at,
    order_lines.source_updated_at
from order_lines
left join products on order_lines.product_id = products.product_id
