using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for role_user
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class role_user : System.Web.Services.WebService
{

    public role_user()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod(enableSession:true)]
    public object GetMenus()
    {
        try
        {
            List<object> menuGroups = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetMenusWithMainMenu", con))
            {
                var roleID = Session["RoleID"].ToString();
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
    public object GetPermissionsByRole(int roleId)
    {
        try
        {
            var result = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetPermissionsByRole", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleID", roleId);

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    var grouped = new Dictionary<int, dynamic>();
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
                            MenuID = Convert.ToInt32(rdr["MenuID"]),
                            MenuName = rdr["MenuName"].ToString(),
                            Url = rdr["Url"].ToString(),
                            CanView = Convert.ToBoolean(rdr["CanView"])
                        });
                    }

                    foreach (var section in grouped.Values)
                        result.Add(section);
                }
            }

            return ApiUtil.Success("Permissions loaded", result);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to load permissions", ex.Message);
        }
    }


    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    [WebMethod]
    public object InsertRole(string RoleID, string RoleName, string Description)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("SaveOrUpdateRole", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleID",Convert.ToInt64(RoleID));
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


    [WebMethod]
    public object GetRoles()
    {
        try
        {
            List<object> roles = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetAllRoles", con))
            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    roles.Add(new
                    {
                        RoleID = rdr["RoleID"],
                        RoleName = rdr["RoleName"].ToString(),
                        Description = rdr["Description"].ToString()
                    });
                }
            }

            return ApiUtil.Success("Roles loaded", roles);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to load roles", ex.Message);
        }
    }


    [WebMethod(EnableSession =true)]
    public object SavePermissions(int RoleID, List<PermissionItem> Permissions)
    {
        try
        {
            DataTable tvp = new DataTable();
            tvp.Columns.Add("MenuID", typeof(int));
            tvp.Columns.Add("CanView", typeof(bool));

            foreach (var perm in Permissions)
                tvp.Rows.Add(perm.MenuID, perm.CanView);

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("SaveOrUpdatePermissions", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleID", RoleID);

                SqlParameter tvpParam = cmd.Parameters.AddWithValue("@Permissions", tvp);
                tvpParam.SqlDbType = SqlDbType.Structured;
                tvpParam.TypeName = "TVP_Permissions";

                cmd.ExecuteNonQuery();
            }

            LogUtil.WriteLog(userId: Convert.ToInt64(Session["UserID"].ToString()), action: "Permissions", details: "user updated the permission for the role id "+RoleID, isSuccess: true);

            return ApiUtil.Success("Permissions saved");
        }
        catch (Exception ex)
        {
            LogUtil.WriteLog(userId: Convert.ToInt64(Session["UserID"].ToString()), action: "Permissions", details: "user Attempt to update the permssion of the role id" + RoleID+" But an error occurred, the error is "+ex.Message, isSuccess: true);

            return ApiUtil.Error("Failed to save permissions", ex.Message);
        }
    }

    public class PermissionItem
    {
        public int MenuID { get; set; }
        public bool CanView { get; set; }
    }

}
