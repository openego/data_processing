/*
Database administration examples and commands

__copyright__ 	= "© Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://www.gnu.org/licenses/agpl-3.0.en.html"
__author__ 	= "Ludwig Hülk"
*/

-- delete active connections
SELECT 	pg_terminate_backend(pid) 
FROM	pg_stat_activity 
WHERE	usename = '';

SELECT *
FROM pg_stat_activity;


pg_stat_activity
pg_stat_archiver
pg_stat_bgwriter
pg_stat_database
pg_stat_all_tables
pg_stat_sys_tables
...
pg_statio_all_tables
pg_statio_sys_tables
pg_statio_user_tables
pg_statio_all_indexes
pg_statio_sys_indexes
