--metadb:function users_by_groups

CREATE FUNCTION users_by_groups(
    start_date date DEFAULT '2000-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    id uuid,
    active_users integer,
    non_active_users integer)
AS $$
 SELECT
   g.desc as patron_group,
   COUNT(CASE WHEN u.active = 'true' THEN 1 END) AS active_users,
   COUNT(CASE WHEN u.active = 'false' THEN 1 END) AS non_active_users,
   COUNT(*) AS total_users
 FROM folio_users.users__t u
 JOIN folio_users.groups__t g ON u.patron_group = g.id
 GROUP BY g.desc
 order BY g.desc ASC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
