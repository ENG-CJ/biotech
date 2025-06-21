using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for HR_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class HR_api : System.Web.Services.WebService
{

    public HR_api()
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
    public object SaveEmployeeSalary(Dictionary<string, object> data)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_SaveEmployeeSalary", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SalaryId", data.ContainsKey("SalaryId") ? Convert.ToInt32(data["SalaryId"]) : 0);
                cmd.Parameters.AddWithValue("@EmployeeId", data["EmployeeId"]);
                cmd.Parameters.AddWithValue("@BasicSalary", data["BasicSalary"]);
                cmd.Parameters.AddWithValue("@Allowance", data["Allowance"]);
                cmd.Parameters.AddWithValue("@Deductions", data["Deductions"]);
                cmd.Parameters.AddWithValue("@Notes", data["Notes"] ?? DBNull.Value);

     
                cmd.ExecuteNonQuery();
            }

            return new ApiResponse(true, "Salary setup saved successfully");
        }
        catch (Exception ex)
        {
            return new ApiResponse(false, ex.Message, "Failed to save salary setup");
        }
    }

    [WebMethod]
    public object GetEmployeeSalaries()
    {
        try
        {
            List<object> data = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetAllEmployeeSalaries", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        data.Add(new
                        {
                            SalaryId = rdr["SalaryId"],
                            EmployeeId = rdr["EmployeeId"],
                            FullName = rdr["FullName"],
                            BasicSalary = rdr["BasicSalary"],
                            Allowance = rdr["Allowance"],
                            Deductions = rdr["Deductions"],
                            Notes = rdr["Notes"],
                            CreatedAt = rdr["CreatedAt"]
                        });
                    }
                }
            }

            return new ApiResponse(true, "Salary setups fetched successfully", data);
        }
        catch (Exception ex)
        {
            return new ApiResponse(false, ex.Message, "Failed to fetch salary setups");
        }
    }


}
