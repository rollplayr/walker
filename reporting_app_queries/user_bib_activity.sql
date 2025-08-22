--metadb:function user_bib_activity

DROP FUNCTION IF EXISTS user_bib_activity;

CREATE FUNCTION user_bib_activity(
    username_filter TEXT DEFAULT NULL,
    start_date DATE DEFAULT '2000-01-01',
    end_date DATE DEFAULT '2050-01-01'
)
RETURNS TABLE(
    user_id UUID,
    username TEXT,
    instances_created INTEGER,
    instances_modified INTEGER,
    holdings_created INTEGER,
    holdings_modified INTEGER,
    items_created INTEGER,
    items_modified INTEGER
)
AS $$
SELECT
    u.id AS user_id,
    u.username AS username,

    -- instances
    COUNT(DISTINCT CASE
        WHEN i.created_by_user_id = u.id
             AND i.record_created_date::date >= start_date
             AND i.record_created_date::date < end_date
        THEN i.id END) AS instances_created,

    COUNT(DISTINCT CASE
        WHEN i.updated_by_user_id = u.id
             AND i.updated_date::date >= start_date
             AND i.updated_date::date < end_date
        THEN i.id END) AS instances_modified,

    -- holdings
    COUNT(DISTINCT CASE
        WHEN h.created_by_user_id = u.id
             AND h.record_created_date::date >= start_date
             AND h.record_created_date::date < end_date
        THEN h.id END) AS holdings_created,

    COUNT(DISTINCT CASE
        WHEN h.updated_by_user_id = u.id
             AND h.updated_date::date >= start_date
             AND h.updated_date::date < end_date
        THEN h.id END) AS holdings_modified,

    -- items
    COUNT(DISTINCT CASE
        WHEN it.created_by_user_id = u.id
             AND it.record_created_date::date >= start_date
             AND it.record_created_date::date < end_date
        THEN it.id END) AS items_created,

    COUNT(DISTINCT CASE
        WHEN it.updated_by_user_id = u.id
             AND it.updated_date::date >= start_date
             AND it.updated_date::date < end_date
        THEN it.id END) AS items_modified

FROM folio_users.users__t u
LEFT JOIN instance_ext i ON (i.created_by_user_id = u.id OR i.updated_by_user_id = u.id)
LEFT JOIN holding_ext h ON (h.created_by_user_id = u.id OR h.updated_by_user_id = u.id)
LEFT JOIN item_ext it ON (it.created_by_user_id = u.id OR it.updated_by_user_id = u.id)

WHERE (username_filter IS NULL OR u.username ILIKE username_filter)

GROUP BY u.id, u.username
ORDER BY u.username;
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
