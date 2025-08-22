--metadb:function user_bib_activity

DROP FUNCTION IF EXISTS user_bib_activity;

CREATE FUNCTION user_bib_activity(
    user_filter UUID DEFAULT NULL,      -- optional filter: user id
    start_date TIMESTAMP DEFAULT NULL,  -- optional filter: record created/updated after
    end_date TIMESTAMP DEFAULT NULL     -- optional filter: record created/updated before
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
        WHEN (i.created_by_user_id = u.id
              AND (start_date IS NULL OR i.record_created_date >= start_date)
              AND (end_date IS NULL OR i.record_created_date <= end_date))
        THEN i.id END) AS instances_created,

    COUNT(DISTINCT CASE
        WHEN (i.updated_by_user_id = u.id
              AND (start_date IS NULL OR i.updated_date >= start_date)
              AND (end_date IS NULL OR i.updated_date <= end_date))
        THEN i.id END) AS instances_modified,

    -- holdings
    COUNT(DISTINCT CASE
        WHEN (h.created_by_user_id = u.id
              AND (start_date IS NULL OR h.record_created_date >= start_date)
              AND (end_date IS NULL OR h.record_created_date <= end_date))
        THEN h.id END) AS holdings_created,

    COUNT(DISTINCT CASE
        WHEN (h.updated_by_user_id = u.id
              AND (start_date IS NULL OR h.updated_date >= start_date)
              AND (end_date IS NULL OR h.updated_date <= end_date))
        THEN h.id END) AS holdings_modified,

    -- items
    COUNT(DISTINCT CASE
        WHEN (it.created_by_user_id = u.id
              AND (start_date IS NULL OR it.record_created_date >= start_date)
              AND (end_date IS NULL OR it.record_created_date <= end_date))
        THEN it.id END) AS items_created,

    COUNT(DISTINCT CASE
        WHEN (it.updated_by_user_id = u.id
              AND (start_date IS NULL OR it.updated_date >= start_date)
              AND (end_date IS NULL OR it.updated_date <= end_date))
        THEN it.id END) AS items_modified

FROM folio_users.users__t u
LEFT JOIN instance_ext i ON (i.created_by_user_id = u.id OR i.updated_by_user_id = u.id)
LEFT JOIN holding_ext h ON (h.created_by_user_id = u.id OR h.updated_by_user_id = u.id)
LEFT JOIN item_ext it ON (it.created_by_user_id = u.id OR it.updated_by_user_id = u.id)

WHERE (user_filter IS NULL OR u.id = user_filter)

GROUP BY u.id, u.username
ORDER BY u.username;
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
