SELECT
  g.desc as patron_group,
  COUNT(CASE WHEN u.active = 'true' THEN 1 END) AS active_users,
  COUNT(CASE WHEN u.active = 'false' THEN 1 END) AS non_active_users,
  COUNT(*) AS total_users
FROM folio_users.users__t u
JOIN folio_users.groups__t g ON u.patron_group = g.id
GROUP BY g.desc
order BY g.desc ASC;
