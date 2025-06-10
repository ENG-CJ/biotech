using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for users_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class users_api : System.Web.Services.WebService
{

    public users_api()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    [WebMethod]
    public object SaveUser(string UserID, string Username, string Email, string Password, long RoleID)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("SaveOrUpdateUser", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserID",Convert.ToInt64(UserID));
                cmd.Parameters.AddWithValue("@Username", Username);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@Password", Password);
                cmd.Parameters.AddWithValue("@RoleID", RoleID);

                cmd.ExecuteNonQuery();
            }

            return ApiUtil.Success("User saved successfully");
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to save user", ex.Message);
        }
    }

    [WebMethod]
    public object GetUsers()
    {
        try
        {
            List<object> users = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetUsersWithRole", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        users.Add(new
                        {
                            UserID = rdr["UserID"],
                            Username = rdr["Username"].ToString(),
                            Email = rdr["Email"].ToString(),
                            RoleID = rdr["RoleID"],
                            RoleName = rdr["RoleName"]?.ToString()
                        });
                    }
                }
            }

            return ApiUtil.Success("Users loaded successfully", users);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to load users", ex.Message);
        }
    }

}
