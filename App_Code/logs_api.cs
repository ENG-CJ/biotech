using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for logs_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class logs_api : System.Web.Services.WebService
{

    public logs_api()
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
    public object GetLogs()
    {
        try
        {
            List<object> logs = new List<object>();

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetLogsWithUserInfo", con))
            {
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        logs.Add(new
                        {
                            LogID = rdr["LogID"],
                            UserID = rdr["UserID"],
                            Username = rdr["Username"]?.ToString(),
                            Email = rdr["Email"]?.ToString(),
                            RoleName = rdr["RoleName"]?.ToString(),
                            Action = rdr["Action"]?.ToString(),
                            Details = rdr["Details"]?.ToString(),
                            IPAddress = rdr["IPAddress"]?.ToString(),
                            UserAgent = rdr["UserAgent"]?.ToString(),
                            IsSuccess = Convert.ToBoolean(rdr["IsSuccess"]),
                            CreatedAt = Convert.ToDateTime(rdr["CreatedAt"]).ToString("yyyy-MM-dd HH:mm:ss")
                        });
                    }
                }
            }

            return ApiUtil.Success("Logs fetched", logs);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Error loading logs", ex.Message);
        }
    }

}
