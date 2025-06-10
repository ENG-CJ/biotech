using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Script.Services;
using System.Web.Services;

namespace biomedical_pos.Api
{
    /// <summary>
    /// Summary description for roles_api
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [ScriptService]
    public class roles_api : WebService
    {
        [WebMethod]
        public object GetData()
        {
            return 1;
        }
            [WebMethod]
        public string HelloWorld()
        {
            return "Hello World";
        }

        [WebMethod]
        public object GetMenus()
        {
            try
            {
                List<object> menuGroups = new List<object>();
                using (SqlConnection con = DB.GetOpenConnection())
                using (SqlCommand cmd = new SqlCommand("GetMenusWithMainMenu", con))
                {
                    var roleID = 6;
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleID", roleID);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        Dictionary<int, dynamic> grouped = new Dictionary<int, dynamic>();
                        while (rdr.Read())
                        {
                            int mainMenuId = Convert.ToInt32(rdr["MainMenuID"]);
                            if (!grouped.ContainsKey(mainMenuId))
                            {
                                grouped[mainMenuId] = new
                                {
                                    MainMenuID = mainMenuId,
                                    MainMenuName = rdr["MainMenuName"].ToString(),
                                    IconClass = rdr["IconClass"].ToString(),
                                    Menus = new List<object>()
                                };
                            }

                            ((List<object>)grouped[mainMenuId].Menus).Add(new
                            {
                                MenuID = rdr["MenuID"],
                                MenuName = rdr["MenuName"].ToString(),
                                Url = rdr["Url"].ToString()
                            });
                        }

                        foreach (var item in grouped.Values)
                            menuGroups.Add(item);
                    }
                }

                return ApiUtil.Success("Menu loaded", menuGroups);
            }
            catch (Exception ex)
            {
                return ApiUtil.Error("Failed to load menus", ex.Message);
            }
        }

     
        

        [WebMethod]
        public object InsertRole(int? RoleID, string RoleName, string Description)
        {
            try
            {
                using (SqlConnection con = DB.GetOpenConnection())
                using (SqlCommand cmd = new SqlCommand("SaveOrUpdateRole", con))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleID", (object)RoleID ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@RoleName", RoleName);
                    cmd.Parameters.AddWithValue("@Description", Description);

                    cmd.ExecuteNonQuery();
                }

                return ApiUtil.Success("Role saved successfully");
            }
            catch (Exception ex)
            {
                return ApiUtil.Error("Failed to save role", ex.Message);
            }
        }
    }
}
