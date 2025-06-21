using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for Employee_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class Employee_api : System.Web.Services.WebService
{

    public Employee_api()
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
    public object SaveEmployeeTitle(int TitleId, string TitleName, string Notes)
    {
        ApiResponse response = new ApiResponse();
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_SaveEmployeeTitle", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TitleId", TitleId);
                cmd.Parameters.AddWithValue("@TitleName", TitleName);
                cmd.Parameters.AddWithValue("@Notes", Notes ?? (object)DBNull.Value);

                cmd.ExecuteNonQuery();
            }

            response = new ApiResponse(true, "Title saved successfully");
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to save title");
        }

        return response;
    }

    [WebMethod]
    public object GetEmployeeTitles()
    {
        ApiResponse response = new ApiResponse();
        List<object> data = new List<object>();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetEmployeeTitles", con))
            {
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        data.Add(new
                        {
                            TitleId = rdr["TitleId"],
                            TitleName = rdr["TitleName"],
                            Notes = rdr["Notes"],
                            CreatedAt = Convert.ToDateTime(rdr["CreatedAt"]).ToString("yyyy-MM-dd HH:mm")
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Titles fetched", data);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to load titles");
        }

        return response;
    }

    [WebMethod]
    public object RegisterEmployee(Dictionary<string, object> employeeData)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            DateTime joinDate = employeeData.ContainsKey("JoinDate") ? Convert.ToDateTime(employeeData["JoinDate"]) : DateTime.MinValue;

            // Validation: JoinDate cannot be in the future
            if (joinDate > DateTime.Now.Date)
                return new ApiResponse(false, "Join Date cannot be in the future");

            using (SqlConnection con = DB.GetOpenConnection())
            {
                using (SqlCommand cmd = new SqlCommand("sp_SaveEmployee", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@EmployeeId", employeeData.ContainsKey("EmployeeId") ? Convert.ToInt32(employeeData["EmployeeId"]) : 0);
                    cmd.Parameters.AddWithValue("@FullName", employeeData.ContainsKey("FullName") ? employeeData["FullName"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Phone", employeeData.ContainsKey("Phone") ? employeeData["Phone"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Email", employeeData.ContainsKey("Email") ? employeeData["Email"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Address", employeeData.ContainsKey("Address") ? employeeData["Address"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@TitleId", employeeData.ContainsKey("TitleId") ? employeeData["TitleId"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@JoinDate", DateTime.Now);
                    cmd.Parameters.AddWithValue("@IsActive", employeeData.ContainsKey("IsActive") ? employeeData["IsActive"] : true);

                    cmd.ExecuteNonQuery();
                }
            }

            response = new ApiResponse(true, "Employee registered/updated successfully");
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to save employee");
        }

        return response;
    }


    [WebMethod]
    public object GetAllEmployees()
    {
        ApiResponse response = new ApiResponse();
        List<object> employees = new List<object>();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetAllEmployees", con))
            {
             
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        employees.Add(new
                        {
                            EmpId = rdr["EmpId"],
                            EmployeeId = rdr["EmployeeId"],
                            FullName = rdr["FullName"],
                            Title = rdr["TitleName"],
                            TitleId = rdr["TitleId"],
                            //Gender = rdr["Gender"],
                            Phone = rdr["Phone"],
                            Email = rdr["Email"],
                            JoinDate = Convert.ToDateTime(rdr["JoinDate"]).ToString("yyyy-MM-dd"),
                            Address = rdr["Address"],
                            //Notes = rdr["Notes"]
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Employees loaded successfully", employees);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to load employees");
        }

        return response;
    }

}
