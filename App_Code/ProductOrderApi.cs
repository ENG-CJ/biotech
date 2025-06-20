using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for ProductOrderApi
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class ProductOrderApi : System.Web.Services.WebService
{

    public ProductOrderApi()
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
    public object SaveOrUpdateProductOrder(int OrderId, int ProductId, int Quantity, string OrderedBy, string Notes, string SupplierId)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_SaveOrUpdateProductOrder", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@OrderId", OrderId);
                cmd.Parameters.AddWithValue("@ProductId", ProductId);
                cmd.Parameters.AddWithValue("@Quantity", Quantity);
                cmd.Parameters.AddWithValue("@OrderedBy", (object)OrderedBy ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Notes", (object)Notes ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@SupplierId", Convert.ToInt32(SupplierId));
                cmd.ExecuteNonQuery();

                response = new ApiResponse(true, "Product order saved successfully");
            }
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to save product order");
        }

        return response;
    }

    [WebMethod]
    public object CompleteProductOrder(int OrderId)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_CompleteProductOrder", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@OrderId", OrderId);

                cmd.ExecuteNonQuery();

                response = new ApiResponse(true, "Order marked as completed and stock updated.");
            }
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to complete order");
        }

        return response;
    }

    [WebMethod]
    public object GetAllProductOrders()
    {
        ApiResponse response = new ApiResponse();
        try
        {
            List<object> orders = new List<object>();

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetAllProductOrders", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
               

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        orders.Add(new
                        {
                            OrderId = rdr["OrderId"],
                            ProductId = rdr["ProductId"],
                            ProductName = rdr["ProductName"],
                            Quantity = rdr["Quantity"],
                            UnitPrice = rdr["UnitPrice"],
                            TotalPrice = rdr["TotalPrice"],
                            Status = rdr["Status"],
                            OrderDate = DateTime.Parse (rdr["OrderDate"].ToString()).ToString("yyyy-MM-dd"),
                            OrderedBy = rdr["OrderedBy"],
                            Notes = rdr["Notes"],
                            SupplierId = rdr["SupplierId"],
                            SupplierName = rdr["SupplierName"]
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Fetched product orders successfully", orders);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to fetch product orders");
        }

        return response;
    }


}
