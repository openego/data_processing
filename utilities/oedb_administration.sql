/*
Database administration examples and commands

__copyright__ 	= "� Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://www.gnu.org/licenses/agpl-3.0.en.html"
__author__ 	= "Ludwig H�lk"
*/

-- delete active connections
SELECT 	pg_terminate_backend(pid) 
FROM	pg_stat_activity 
WHERE	usename = '';
