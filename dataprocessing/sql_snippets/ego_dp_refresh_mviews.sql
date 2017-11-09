/*
SQL Script to Refresh materializied Views

__copyright__ = "Europa-Universität Flensburgs, Centre for Sustainable Energy Systems"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/


-- Power plant MViews
REFRESH MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_sq_mview;
REFRESH MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_nep2035_mview;
REFRESH MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_ego100_mview;

REFRESH MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_sq_mview;
REFRESH MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_nep2035_mview;
REFRESH MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_ego100_mview;
