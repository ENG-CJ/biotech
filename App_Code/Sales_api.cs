using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;

/// <summary>
/// Summary description for Sales_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class Sales_api : System.Web.Services.WebService
{

    public Sales_api()
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
    public object GetSaleProducts()
    {
        ApiResponse response = new ApiResponse();

        try
        {
            List<object> products = new List<object>();

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetSaleProducts", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        products.Add(new
                        {
                            ProductId = rdr["ProductId"],
                            ProductName = rdr["ProductName"],
                            Price = rdr["Price"],
                            StockQuantity = rdr["StockQuantity"],
                            StockStatus = rdr["StockStatus"]
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Products fetched", products);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to fetch products");
        }

        return response;
    }


    [WebMethod]
    public object RegisterSale(int CustomerId, string PaymentType, decimal PaidAmount, List<SaleItem> saleDetails)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            if (saleDetails == null || saleDetails.Count == 0)
                return new ApiResponse(false, "Cart is empty", "No items provided");

            int newSaleId = 0;
            decimal totalAmount = 0;

            foreach (var item in saleDetails)
            {
                totalAmount += item.Price * item.Quantity;
            }

            using (SqlConnection con = DB.GetOpenConnection())
            {
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        // 1. Insert Sale Info
                        using (SqlCommand cmd = new SqlCommand("sp_SaveSaleInfo", con, tran))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@CustomerId", CustomerId);
                            cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                            cmd.Parameters.AddWithValue("@PaidAmount", PaidAmount);
                            cmd.Parameters.AddWithValue("@PaymentType", PaymentType);
                            cmd.Parameters.AddWithValue("@Notes", DBNull.Value);

                            SqlParameter output = new SqlParameter("@NewSaleId", SqlDbType.Int)
                            {
                                Direction = ParameterDirection.Output
                            };
                            cmd.Parameters.Add(output);
                            cmd.ExecuteNonQuery();

                            newSaleId = Convert.ToInt32(output.Value);
                        }

                        // 2. Insert Each Item in Sale Details
                        foreach (var item in saleDetails)
                        {
                            using (SqlCommand cmd = new SqlCommand("sp_SaveSaleDetail", con, tran))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@SaleId", newSaleId);
                                cmd.Parameters.AddWithValue("@ProductId", item.ProductId);
                                cmd.Parameters.AddWithValue("@Quantity", item.Quantity);
                                cmd.Parameters.AddWithValue("@UnitPrice", item.Price);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                        response = new ApiResponse(true, "Sale completed successfully", new { SaleId = newSaleId });
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        response = new ApiResponse(false, ex.Message, "Transaction failed");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Unexpected error occurred");
        }

        return response;
    }
    public class SaleItem
    {
        public int ProductId { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
    }

    [WebMethod]
    public object GetAllSales()
    {
        ApiResponse response = new ApiResponse();

        try
        {
            List<object> salesList = new List<object>();

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetAllSales", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
           
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        salesList.Add(new
                        {
                            SaleId = rdr["SaleId"],
                            CustomerName = rdr["CustomerName"],
                            SaleDate = Convert.ToDateTime(rdr["SaleDate"]).ToString("yyyy-MM-dd HH:mm"),
                            TotalAmount = rdr["TotalAmount"],
                            PaidAmount = rdr["PaidAmount"],
                            PaymentType = rdr["PaymentType"],
                            Notes = rdr["Notes"]
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Sales loaded successfully", salesList);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to load sales");
        }

        return response;
    }

    [WebMethod]
    public object CancelSale(int SaleId)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_CancelSale", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SaleId", SaleId);
       
                cmd.ExecuteNonQuery();
            }

            response = new ApiResponse(true, "Sale cancelled and stock restored");
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to cancel sale");
        }

        return response;
    }
    [WebMethod]
    public object GetSaleDetails(int SaleId)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            List<object> items = new List<object>();

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetSaleDetailsBySaleId", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SaleId", SaleId);
             

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        items.Add(new
                        {
                            SaleDetailId = rdr["SaleDetailId"],
                            SaleId = rdr["SaleId"],
                            ProductId = rdr["ProductId"],
                            ProductName = rdr["ProductName"],
                            Quantity = rdr["Quantity"],
                            UnitPrice = rdr["UnitPrice"],
                            TotalPrice = rdr["TotalPrice"]
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Sale detail loaded", items);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to load sale detail");
        }

        return response;
    }

    [WebMethod]
    public object RemoveSaleItem(int SaleDetailId, int ProductId, int Quantity)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_RemoveSaleDetailItem", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SaleDetailId", SaleDetailId);
                cmd.Parameters.AddWithValue("@ProductId", ProductId);
                cmd.Parameters.AddWithValue("@Quantity", Quantity);
               
                cmd.ExecuteNonQuery();
            }

            return new ApiResponse(true, "Sale item removed and stock updated");
        }
        catch (Exception ex)
        {
            return new ApiResponse(false, ex.Message, "Failed to remove sale item");
        }
    }

    [WebMethod]
    public object GetSaleInvoiceData(int SaleId)
    {
        try
        {
            object saleInfo = null;
            List<object> saleItems = new List<object>();

            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetSaleInvoiceData", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SaleId", SaleId);

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    // Read sale info
                    if (rdr.Read())
                    {
                        saleInfo = new
                        {
                            SaleId = rdr["SaleId"],
                            SaleDate = Convert.ToDateTime(rdr["SaleDate"]).ToString("yyyy-MM-dd HH:mm"),
                            CustomerName = rdr["CustomerName"],
                            PaymentType = rdr["PaymentType"],
                            PaidAmount = rdr["PaidAmount"],
                            TotalAmount = rdr["TotalAmount"]
                        };
                    }

                    // Read item details
                    if (rdr.NextResult())
                    {
                        while (rdr.Read())
                        {
                            saleItems.Add(new
                            {
                                ProductName = rdr["ProductName"],
                                Quantity = rdr["Quantity"],
                                UnitPrice = rdr["UnitPrice"],
                                Total = rdr["Total"]
                            });
                        }
                    }
                }
            }

            var result = new
            {
                Info = saleInfo,
                Items = saleItems
            };

            return new ApiResponse(true, "Invoice loaded", result);
        }
        catch (Exception ex)
        {
            return new ApiResponse(false, ex.Message, "Failed to load invoice");
        }
    }

    [WebMethod]
    public object ProcessSaleReturn(int SaleId, string ReturnedBy, string Notes, decimal TotalRefund, List<ReturnItem> Items)
    {
        ApiResponse response = new ApiResponse();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_ProcessSaleReturn", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SaleId", SaleId);
                cmd.Parameters.AddWithValue("@ReturnedBy", ReturnedBy);
                cmd.Parameters.AddWithValue("@Notes", (object)Notes ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TotalRefund", TotalRefund);

                // TVP: table-valued parameter
                DataTable returnItemsTable = new DataTable();
                returnItemsTable.Columns.Add("ProductId", typeof(int));
                returnItemsTable.Columns.Add("Quantity", typeof(int));
                returnItemsTable.Columns.Add("UnitPrice", typeof(decimal));

                foreach (var item in Items)
                {
                    returnItemsTable.Rows.Add(item.ProductId, item.Quantity, item.UnitPrice);
                }

                SqlParameter tvp = new SqlParameter("@ReturnItems", returnItemsTable)
                {
                    SqlDbType = SqlDbType.Structured,
                    TypeName = "ReturnItemTableType"
                };

                cmd.Parameters.Add(tvp);


                cmd.ExecuteNonQuery();

                response = new ApiResponse(true, "Sale return processed successfully");
            }
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to process return");
        }

        return response;
    }

    // Helper DTO class
    public class ReturnItem
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
    }



}
