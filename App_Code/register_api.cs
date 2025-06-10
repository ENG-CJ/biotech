using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI.WebControls;

/// <summary>
/// Summary description for register_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class register_api : System.Web.Services.WebService
{

    public register_api()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    [WebMethod(enableSession:true)]
    public object SaveCustomer(string CustomerID, string FullName, string Phone, string Email, string Address)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("SaveOrUpdateCustomer", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt64(CustomerID));
                cmd.Parameters.AddWithValue("@FullName", FullName);
                cmd.Parameters.AddWithValue("@Phone", Phone ?? "");
                cmd.Parameters.AddWithValue("@Email", Email ?? "");
                cmd.Parameters.AddWithValue("@Address", Address ?? "");

                cmd.ExecuteNonQuery();
            }

            LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Customer Insertion", details: $"user Attempt to Added new customer named {FullName}", isSuccess: true);

            return ApiUtil.Success("Customer saved successfully");
        }
        catch (Exception ex)
        {
            LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Customer Insertion", details: $"user Attempt to Added new customer named {FullName} but error occured", isSuccess: false);

            return ApiUtil.Error("Failed to save customer", ex.Message);
        }
    }

    [WebMethod]
    public object GetCustomers()
    {
        try
        {
            List<object> list = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetCustomers", con))
            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    list.Add(new
                    {
                        CustomerID = rdr["CustomerID"],
                        FullName = rdr["FullName"].ToString(),
                        Phone = rdr["Phone"].ToString(),
                        Email = rdr["Email"].ToString(),
                        Address = rdr["Address"].ToString()
                    });
                }
            }

            return ApiUtil.Success("Customers loaded", list);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to load customers", ex.Message);
        }
    }


    [WebMethod(enableSession:true)]
    public object SaveSupplier(string SupplierID, string SupplierName, string Mobile, string Email, string Address, string CompanyName)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("SaveOrUpdateSupplier", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SupplierID", Convert.ToInt64(SupplierID));
                cmd.Parameters.AddWithValue("@SupplierName", SupplierName);
                cmd.Parameters.AddWithValue("@Mobile", Mobile);
                cmd.Parameters.AddWithValue("@Email", (object)Email ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Address", (object)Address ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@CompanyName", (object)CompanyName ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
            LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Suuplier Insertion", details: $"user Added new supplier named {SupplierName}", isSuccess: true);

            return ApiUtil.Success("Supplier saved successfully.");
        }
        catch (Exception ex)
        {
            LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Suuplier Insertion", details: $"user Attempt to Added new supplier named {SupplierName} but error occured", isSuccess: false);

            return ApiUtil.Error("Failed to save supplier", ex.Message);
        }
    }

    [WebMethod]
    public object GetSuppliers()
    {
        try
        {
            List<object> suppliers = new List<object>();
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("GetAllSuppliers", con))
            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    suppliers.Add(new
                    {
                        SupplierID = rdr["SupplierID"],
                        SupplierName = rdr["SupplierName"],
                        Mobile = rdr["Mobile"],
                        Email = rdr["Email"],
                        Address = rdr["Address"],
                        CompanyName = rdr["CompanyName"]
                    });
                }
            }

            return ApiUtil.Success("Suppliers loaded", suppliers);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to load suppliers", ex.Message);
        }
    }


}
