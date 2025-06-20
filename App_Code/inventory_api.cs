using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for inventory_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class inventory_api : System.Web.Services.WebService
{

    public inventory_api()
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
    public  object SaveProduct(Dictionary<string, object> product)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            {
                using (SqlCommand cmd = new SqlCommand("SaveOrUpdateProduct", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ProductID", Convert.ToInt64(product["ProductID"]));
                    cmd.Parameters.AddWithValue("@ProductName", product["ProductName"]);
                    cmd.Parameters.AddWithValue("@ReorderLevel", product["ReorderLevel"] ?? (object)DBNull.Value);

                    cmd.Parameters.AddWithValue("@ProductCode", product["ProductCode"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Description", product["Description"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Unit", product["Unit"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@CategoryID", product["CategoryID"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Brand", product["Brand"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@CostPrice", product["CostPrice"]);
                    cmd.Parameters.AddWithValue("@SellingPrice", product["SellingPrice"]);
                    cmd.Parameters.AddWithValue("@HasInitialQty", product["HasInitialQty"]);
                    cmd.Parameters.AddWithValue("@Quantity", product["Quantity"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ExpiryDate", product["ExpiryDate"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Barcode", product["Barcode"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Status", product["Status"]);
                    cmd.Parameters.AddWithValue("@Notes", product["Notes"] ?? DBNull.Value);
                    cmd.ExecuteNonQuery();

                    LogUtil.WriteLog(Convert.ToInt64(Session["UserID"]), "Product", "User Saved/Updated Product Named " + product["ProductName"], true);
                    response = new ApiResponse(true, "Product saved successfully.");
                }
            }
        }
        catch (Exception ex)
        {
            LogUtil.WriteLog(Convert.ToInt64(Session["UserID"]), "Product", "User Attempt to Save/Update Product Named " + product["ProductName"]+" But error occured "+ex.Message, false);

            response = new ApiResponse(false, ex.Message, "Failed to save product.");
        }

        return response;
    }
    [WebMethod]
    public  object GetProducts()
    {
        ApiResponse response = new ApiResponse();
        List<object> products = new List<object>();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            {
                SqlCommand cmd = new SqlCommand("GetProductsWithCategory", con);
                cmd.CommandType = CommandType.StoredProcedure;
          

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        products.Add(new
                        {
                            ProductID = dr["ProductID"],
                            ProductName = dr["ProductName"],
                            ProductCode = dr["ProductCode"],
                            Description = dr["Description"],
                            Unit = dr["Unit"],
                            CategoryID = dr["CategoryID"],
                            CategoryName = dr["CategoryName"],
                            Brand = dr["Brand"],
                            CostPrice = dr["CostPrice"],
                            SellingPrice = dr["SellingPrice"],
                            HasInitialQty = dr["HasInitialQty"],
                            Quantity = dr["Quantity"],
                            ExpiryDate = dr["ExpiryDate"],
                            Barcode = dr["Barcode"],
                            Status = dr["Status"],
                            reorderLevel = dr["ReorderLevel"],
                            Notes = dr["Notes"],
                            CreatedAt = dr["CreatedAt"],
                            UpdatedAt = dr["UpdatedAt"]
                        });
                    }
                }

                response = new ApiResponse(true, "Products loaded", products);
            }
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to load products");
        }

        return response;
    }

    [WebMethod]
    public  object GetInventoryReport()
    {
        ApiResponse response = new ApiResponse();
        try
        {
            List<Dictionary<string, object>> items = new List<Dictionary<string, object>>();

            using (SqlConnection conn = DB.GetOpenConnection())
            {
                
                using (SqlCommand cmd = new SqlCommand("GetInventoryReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var row = new Dictionary<string, object>();
                            for (int i = 0; i < rdr.FieldCount; i++)
                            {
                                row[rdr.GetName(i)] = rdr[i];
                            }
                            items.Add(row);
                        }
                    }
                }
            }

            response = new ApiResponse(true, "Inventory report loaded", items);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, "Error loading inventory", null)
            {
                Error = ex.Message
            };
        }

        return response;
    }

    [WebMethod]
    public  object SaveOrUpdateCategory(Dictionary<string, object> data)
    {
        try
        {
            using (var con = DB.GetOpenConnection())
            {
              
                using (var cmd = new SqlCommand("SaveOrUpdateCategory", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CategoryID", data.ContainsKey("CategoryID") ? Convert.ToInt64(data["CategoryID"]) : 0);
                    cmd.Parameters.AddWithValue("@CategoryName", data["CategoryName"]?.ToString());

                    cmd.ExecuteNonQuery();
                }
            }

            return new ApiResponse(true, "Category saved successfully");
        }
        catch (Exception ex)
        {
            return new ApiResponse(false, ex.Message, "Failed to save category");
        }
    }

    [WebMethod]
    public  object GetAllCategories()
    {
        try
        {
            var list = new List<Dictionary<string, object>>();
            using (var con = DB.GetOpenConnection())
            {
               
                using (var cmd = new SqlCommand("GetAllCategories", con))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new Dictionary<string, object>
                        {
                            ["CategoryID"] = reader["CategoryID"],
                            ["CategoryName"] = reader["CategoryName"]
                        });
                    }
                }
            }

            return new ApiResponse(true, "Success", list);
        }
        catch (Exception ex)
        {
            return new ApiResponse(false, ex.Message, "Error loading categories");
        }
    }


}
