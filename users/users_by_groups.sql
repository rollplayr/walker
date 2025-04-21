--metadb:function users_by_groups

CREATE FUNCTION users_by_groups
RETURNS TABLE(
    patron_group desc,
    active_users integer,
    non_active_users integer,
    total_users integer)
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
