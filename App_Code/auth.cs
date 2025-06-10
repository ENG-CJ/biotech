using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for auth
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class auth : System.Web.Services.WebService
{

    public auth()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    [WebMethod(EnableSession = true)]
    public object LoginUser(string username, string password)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("ValidateUserLogin", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@Password", password);

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        
                        HttpContext.Current.Session["UserID"] = rdr["UserID"];
                        HttpContext.Current.Session["Username"] = rdr["Username"];
                        HttpContext.Current.Session["Email"] = rdr["Email"];
                        HttpContext.Current.Session["RoleID"] = rdr["RoleID"];
                        HttpContext.Current.Session["RoleName"] = rdr["RoleName"];

                        var userData = new
                        {
                            UserID = rdr["UserID"],
                            Username = rdr["Username"].ToString(),
                            Email = rdr["Email"].ToString(),
                            RoleID = rdr["RoleID"],
                            RoleName = rdr["RoleName"].ToString()
                        };
                        LogUtil.WriteLog(userId: Convert.ToInt64(rdr["UserID"].ToString()), action: "Login", details: "user attempt to login,Login success", isSuccess: true);

                        return ApiUtil.Success("Login successful", userData);
                    }
                    else
                    {
                        LogUtil.WriteLog(null, "Login", "Invalid credentials for username: "+username, false);

                        return ApiUtil.Error("Invalid username or password", null);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteLog(null, "Login", "An exception or server error occured here is the error: "+ex.Message, false);

            return ApiUtil.Error("Login failed", ex.Message);
        }
    }


}
