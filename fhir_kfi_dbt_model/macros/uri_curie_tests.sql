{#
    Cross-database regex match helper used by the uri_or_curie_format /
    valid_uri_format generic tests below. dbt-core has no built-in
    cross-adapter regex macro, so this branches on target.type directly.
    Extend the elif chain if your project targets an adapter not listed
    here (e.g. databricks/spark: use `{{ column_name }} rlike '{{ raw_pattern }}'`).
#}
{% macro _uri_curie_regex_match(column_name, raw_pattern) %}
{%- if target.type == 'bigquery' -%}
    regexp_contains({{ column_name }}, r'{{ raw_pattern }}')
{%- elif target.type == 'snowflake' -%}
    regexp_like({{ column_name }}, '{{ raw_pattern }}')
{%- else -%}
    {#- postgres, redshift, duckdb, and most others support POSIX ARE `~` -#}
    {{ column_name }} ~ '{{ raw_pattern }}'
{%- endif -%}
{% endmacro %}

{#
    Validates that a column's non-null values are lexically well-formed as
    either a full URI (scheme:hier-part...) or a CURIE (prefix:reference),
    matching LinkML's `uriorcurie` type. Both forms share the same basic
    grammar -- a leading token made of letters/digits/+/-/. followed by a
    colon and a non-empty, whitespace-free remainder -- so a single
    permissive regex covers both:

        ^[A-Za-z][A-Za-z0-9+.-]*:\S+$

    This intentionally does NOT validate that the scheme/prefix is a
    registered IANA URI scheme or a prefix declared in the schema's
    `prefixes:` block -- it's a lexical sanity check (catches empty
    strings, missing colons, embedded whitespace, bare words, etc.), not
    a full URI/CURIE grammar or prefix-registry validator.
#}
{% test uri_or_curie_format(model, column_name) %}

with validation as (

    select {{ column_name }} as value_to_check
    from {{ model }}
    where {{ column_name }} is not null

),

validation_errors as (

    select value_to_check
    from validation
    where not (
        {{ _uri_curie_regex_match(
            column_name='value_to_check',
            raw_pattern='^[A-Za-z][A-Za-z0-9+.-]*:\S+$'
        ) }}
    )

)

select *
from validation_errors

{% endtest %}

{#
    Validates that a column's non-null values are lexically well-formed as
    a full URI, matching LinkML's `uri` type. Uses the same permissive
    scheme:rest pattern as uri_or_curie_format above (LinkML's `uri` type
    doesn't require a scheme registered with IANA, so this is deliberately
    not stricter than the CURIE test) -- kept as a separate named test so
    it can be tightened independently later, e.g. to require a `://`
    authority component for schemas that mandate fully resolvable URIs.
#}
{% test valid_uri_format(model, column_name) %}

with validation as (

    select {{ column_name }} as value_to_check
    from {{ model }}
    where {{ column_name }} is not null

),

validation_errors as (

    select value_to_check
    from validation
    where not (
        {{ _uri_curie_regex_match(
            column_name='value_to_check',
            raw_pattern='^[A-Za-z][A-Za-z0-9+.-]*:\S+$'
        ) }}
    )

)

select *
from validation_errors

{% endtest %}
