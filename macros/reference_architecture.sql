{% macro json_get_string(json_column, json_path) -%}
    {{ return(adapter.dispatch('json_get_string')(json_column, json_path)) }}
{%- endmacro %}

{% macro default__json_get_string(json_column, json_path) -%}
    json_value({{ json_column }}, '{{ json_path }}')
{%- endmacro %}

{% macro duckdb__json_get_string(json_column, json_path) -%}
    json_extract_string({{ json_column }}, '{{ json_path }}')
{%- endmacro %}

{% macro postgres__json_get_string(json_column, json_path) -%}
    ({{ json_column }}::jsonb #>> string_to_array(replace('{{ json_path }}', '$.', ''), '.'))
{%- endmacro %}

{% macro cast_timestamp(expression) -%}
    {{ return(adapter.dispatch('cast_timestamp')(expression)) }}
{%- endmacro %}

{% macro default__cast_timestamp(expression) -%}
    cast({{ expression }} as timestamp)
{%- endmacro %}

{% macro bigquery__cast_timestamp(expression) -%}
    cast({{ expression }} as timestamp)
{%- endmacro %}

{% macro string_literal(value) -%}
    '{{ value | replace("'", "''") }}'
{%- endmacro %}

{% macro customer_payload() -%}
    {{ return(adapter.dispatch('customer_payload')()) }}
{%- endmacro %}

{% macro duckdb__customer_payload() -%}
    to_json(struct_pack(customer_id := id, customer_name := name))
{%- endmacro %}

{% macro default__customer_payload() -%}
    to_json(struct(customer_id as customer_id, customer_name as customer_name))
{%- endmacro %}

{% macro order_payload() -%}
    {{ return(adapter.dispatch('order_payload')()) }}
{%- endmacro %}

{% macro duckdb__order_payload() -%}
    to_json(struct_pack(
        order_id := id,
        customer_id := customer,
        ordered_at := ordered_at,
        store_id := store_id,
        subtotal_cents := subtotal,
        tax_paid_cents := tax_paid,
        order_total_cents := order_total
    ))
{%- endmacro %}

{% macro default__order_payload() -%}
    to_json(struct(
        id as order_id,
        customer as customer_id,
        ordered_at as ordered_at,
        store_id as store_id,
        subtotal as subtotal_cents,
        tax_paid as tax_paid_cents,
        order_total as order_total_cents
    ))
{%- endmacro %}

{% macro payment_payload(payment_id_expression, order_id_expression, amount_expression, method_expression, paid_at_expression) -%}
    {{ return(adapter.dispatch('payment_payload')(payment_id_expression, order_id_expression, amount_expression, method_expression, paid_at_expression)) }}
{%- endmacro %}

{% macro duckdb__payment_payload(payment_id_expression, order_id_expression, amount_expression, method_expression, paid_at_expression) -%}
    to_json(struct_pack(
        payment_id := {{ payment_id_expression }},
        order_id := {{ order_id_expression }},
        amount_cents := {{ amount_expression }},
        payment_method := {{ method_expression }},
        paid_at := {{ paid_at_expression }}
    ))
{%- endmacro %}

{% macro default__payment_payload(payment_id_expression, order_id_expression, amount_expression, method_expression, paid_at_expression) -%}
    to_json(struct(
        {{ payment_id_expression }} as payment_id,
        {{ order_id_expression }} as order_id,
        {{ amount_expression }} as amount_cents,
        {{ method_expression }} as payment_method,
        {{ paid_at_expression }} as paid_at
    ))
{%- endmacro %}

{% macro product_payload() -%}
    {{ return(adapter.dispatch('product_payload')()) }}
{%- endmacro %}

{% macro duckdb__product_payload() -%}
    to_json(struct_pack(
        product_id := sku,
        product_name := name,
        product_type := type,
        price_cents := price,
        product_description := description
    ))
{%- endmacro %}

{% macro default__product_payload() -%}
    to_json(struct(
        sku as product_id,
        name as product_name,
        type as product_type,
        price as price_cents,
        description as product_description
    ))
{%- endmacro %}

{% macro order_line_payload() -%}
    {{ return(adapter.dispatch('order_line_payload')()) }}
{%- endmacro %}

{% macro duckdb__order_line_payload() -%}
    to_json(struct_pack(
        order_line_id := id,
        order_id := order_id,
        product_id := sku,
        quantity := 1
    ))
{%- endmacro %}

{% macro default__order_line_payload() -%}
    to_json(struct(
        id as order_line_id,
        order_id as order_id,
        sku as product_id,
        1 as quantity
    ))
{%- endmacro %}

{% macro user_payload(user_id_expression, customer_name_expression, email_expression, phone_expression, status_expression, created_at_expression) -%}
    {{ return(adapter.dispatch('user_payload')(user_id_expression, customer_name_expression, email_expression, phone_expression, status_expression, created_at_expression)) }}
{%- endmacro %}

{% macro duckdb__user_payload(user_id_expression, customer_name_expression, email_expression, phone_expression, status_expression, created_at_expression) -%}
    to_json(struct_pack(
        user_id := {{ user_id_expression }},
        user_name := {{ customer_name_expression }},
        email_address := {{ email_expression }},
        phone_number := {{ phone_expression }},
        user_status := {{ status_expression }},
        created_at := {{ created_at_expression }}
    ))
{%- endmacro %}

{% macro default__user_payload(user_id_expression, customer_name_expression, email_expression, phone_expression, status_expression, created_at_expression) -%}
    to_json(struct(
        {{ user_id_expression }} as user_id,
        {{ customer_name_expression }} as user_name,
        {{ email_expression }} as email_address,
        {{ phone_expression }} as phone_number,
        {{ status_expression }} as user_status,
        {{ created_at_expression }} as created_at
    ))
{%- endmacro %}

{% macro customer_user_payload(relationship_id_expression, customer_id_expression, user_id_expression, relationship_role_expression, is_primary_contact_expression, valid_from_expression, valid_to_expression) -%}
    {{ return(adapter.dispatch('customer_user_payload')(relationship_id_expression, customer_id_expression, user_id_expression, relationship_role_expression, is_primary_contact_expression, valid_from_expression, valid_to_expression)) }}
{%- endmacro %}

{% macro duckdb__customer_user_payload(relationship_id_expression, customer_id_expression, user_id_expression, relationship_role_expression, is_primary_contact_expression, valid_from_expression, valid_to_expression) -%}
    to_json(struct_pack(
        customer_user_relationship_id := {{ relationship_id_expression }},
        customer_id := {{ customer_id_expression }},
        user_id := {{ user_id_expression }},
        relationship_role := {{ relationship_role_expression }},
        is_primary_contact := {{ is_primary_contact_expression }},
        valid_from := {{ valid_from_expression }},
        valid_to := {{ valid_to_expression }}
    ))
{%- endmacro %}

{% macro default__customer_user_payload(relationship_id_expression, customer_id_expression, user_id_expression, relationship_role_expression, is_primary_contact_expression, valid_from_expression, valid_to_expression) -%}
    to_json(struct(
        {{ relationship_id_expression }} as customer_user_relationship_id,
        {{ customer_id_expression }} as customer_id,
        {{ user_id_expression }} as user_id,
        {{ relationship_role_expression }} as relationship_role,
        {{ is_primary_contact_expression }} as is_primary_contact,
        {{ valid_from_expression }} as valid_from,
        {{ valid_to_expression }} as valid_to
    ))
{%- endmacro %}

{% macro address_payload(address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, created_at_expression) -%}
    {{ return(adapter.dispatch('address_payload')(address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, created_at_expression)) }}
{%- endmacro %}

{% macro duckdb__address_payload(address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, created_at_expression) -%}
    to_json(struct_pack(
        address_id := {{ address_id_expression }},
        address_line_1 := {{ line1_expression }},
        city := {{ city_expression }},
        state := {{ state_expression }},
        postal_code := {{ postal_code_expression }},
        country_code := {{ country_expression }},
        created_at := {{ created_at_expression }}
    ))
{%- endmacro %}

{% macro default__address_payload(address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, created_at_expression) -%}
    to_json(struct(
        {{ address_id_expression }} as address_id,
        {{ line1_expression }} as address_line_1,
        {{ city_expression }} as city,
        {{ state_expression }} as state,
        {{ postal_code_expression }} as postal_code,
        {{ country_expression }} as country_code,
        {{ created_at_expression }} as created_at
    ))
{%- endmacro %}

{% macro customer_address_payload(relationship_id_expression, customer_id_expression, address_id_expression, address_usage_expression, is_default_address_expression, valid_from_expression, valid_to_expression) -%}
    {{ return(adapter.dispatch('customer_address_payload')(relationship_id_expression, customer_id_expression, address_id_expression, address_usage_expression, is_default_address_expression, valid_from_expression, valid_to_expression)) }}
{%- endmacro %}

{% macro duckdb__customer_address_payload(relationship_id_expression, customer_id_expression, address_id_expression, address_usage_expression, is_default_address_expression, valid_from_expression, valid_to_expression) -%}
    to_json(struct_pack(
        customer_address_relationship_id := {{ relationship_id_expression }},
        customer_id := {{ customer_id_expression }},
        address_id := {{ address_id_expression }},
        address_usage := {{ address_usage_expression }},
        is_default_address := {{ is_default_address_expression }},
        valid_from := {{ valid_from_expression }},
        valid_to := {{ valid_to_expression }}
    ))
{%- endmacro %}

{% macro default__customer_address_payload(relationship_id_expression, customer_id_expression, address_id_expression, address_usage_expression, is_default_address_expression, valid_from_expression, valid_to_expression) -%}
    to_json(struct(
        {{ relationship_id_expression }} as customer_address_relationship_id,
        {{ customer_id_expression }} as customer_id,
        {{ address_id_expression }} as address_id,
        {{ address_usage_expression }} as address_usage,
        {{ is_default_address_expression }} as is_default_address,
        {{ valid_from_expression }} as valid_from,
        {{ valid_to_expression }} as valid_to
    ))
{%- endmacro %}

{% macro order_address_snapshot_payload(snapshot_id_expression, order_id_expression, customer_id_expression, address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, captured_at_expression) -%}
    {{ return(adapter.dispatch('order_address_snapshot_payload')(snapshot_id_expression, order_id_expression, customer_id_expression, address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, captured_at_expression)) }}
{%- endmacro %}

{% macro duckdb__order_address_snapshot_payload(snapshot_id_expression, order_id_expression, customer_id_expression, address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, captured_at_expression) -%}
    to_json(struct_pack(
        order_address_snapshot_id := {{ snapshot_id_expression }},
        order_id := {{ order_id_expression }},
        customer_id := {{ customer_id_expression }},
        source_address_id := {{ address_id_expression }},
        address_line_1 := {{ line1_expression }},
        city := {{ city_expression }},
        state := {{ state_expression }},
        postal_code := {{ postal_code_expression }},
        country_code := {{ country_expression }},
        captured_at := {{ captured_at_expression }}
    ))
{%- endmacro %}

{% macro default__order_address_snapshot_payload(snapshot_id_expression, order_id_expression, customer_id_expression, address_id_expression, line1_expression, city_expression, state_expression, postal_code_expression, country_expression, captured_at_expression) -%}
    to_json(struct(
        {{ snapshot_id_expression }} as order_address_snapshot_id,
        {{ order_id_expression }} as order_id,
        {{ customer_id_expression }} as customer_id,
        {{ address_id_expression }} as source_address_id,
        {{ line1_expression }} as address_line_1,
        {{ city_expression }} as city,
        {{ state_expression }} as state,
        {{ postal_code_expression }} as postal_code,
        {{ country_expression }} as country_code,
        {{ captured_at_expression }} as captured_at
    ))
{%- endmacro %}
