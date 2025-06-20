using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for general
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class general : System.Web.Services.WebService
{

    public general()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }
    public static void IncrementStoreStock(int productId, decimal quantity, string note = "UPDATED FROM PRODUCT CREATION")
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            {
                using (SqlCommand cmd = new SqlCommand("sp_IncrementProductStock", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ProductId", productId);
                    cmd.Parameters.AddWithValue("@Quantity", quantity);
                    cmd.Parameters.AddWithValue("@Note", (object)note ?? DBNull.Value);;
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            // You can log the exception or rethrow
           
        }
    }

    [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }

    [WebMethod(enableSession:true)]
    public object DeleteItem(string table, string id)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("SmartDeleteRecord", con))
            {
                cmd.Parameters.Clear();
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TableName", table);
                cmd.Parameters.AddWithValue("@IdValue", Convert.ToInt64(id));

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        int result = Convert.ToInt32(rdr["Result"]);
                        string msg = rdr["Msg"].ToString();

                        if (result == 1)
                        {
                            LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Deletion", details: $"user attempt to Delete a data from {table} with ID {id}. Succeed", isSuccess: true);
                            return ApiUtil.Success(msg);

                        }
                        else
                          {  LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Deletion", details: $"user attempt to Delete a data from {table} with ID {id}. but error occured", isSuccess: false);

                            return ApiUtil.Error(msg);
                        }
                    }
                }

                return ApiUtil.Error("Unknown deletion result");
            }
        }
        catch (Exception ex)
        {
            
                LogUtil.WriteLog(userId: Convert.ToInt64(HttpContext.Current.Session["UserID"].ToString()), action: "Deletion", details: $"user attempt to Delete a data from {table} with ID {id}. but error occured, {ex.Message}", isSuccess: false);

                return ApiUtil.Error("Failed to delete", ex.Message);
        }
    }

    [WebMethod]
    public object GetDropdownData(string tableName, string valueColumn, string textColumn, string defaultText = null)
    {
        try
        {
            List<object> items = new List<object>();

            string pureTable = tableName;
            string[] extraCols = null;

            // Check for extra keyword in tableName (e.g., Products|extra=Price,Cost)
            if (tableName.Contains("|extra="))
            {
                var parts = tableName.Split(new[] { "|extra=" }, StringSplitOptions.None);
                pureTable = parts[0];
                extraCols = parts[1].Split(',');
            }

            if (!string.IsNullOrWhiteSpace(defaultText))
            {
                items.Add(new { Value = "0", Text = defaultText });
            }

            using (SqlConnection con = DB.GetOpenConnection())
            {
                string selectClause = $"[{valueColumn}] AS Value, [{textColumn}] AS Text";
                if (extraCols != null)
                {
                    foreach (var col in extraCols)
                    {
                        selectClause += $", [{col.Trim()}]";
                    }
                }

                string sql = $"SELECT {selectClause} FROM [{pureTable}] ORDER BY [{textColumn}] ASC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var row = new Dictionary<string, object>
                        {
                            ["Value"] = rdr["Value"].ToString(),
                            ["Text"] = rdr["Text"].ToString()
                        };

                        if (extraCols != null)
                        {
                            var extra = new Dictionary<string, object>();
                            foreach (var col in extraCols)
                            {
                                string clean = col.Trim();
                                extra[clean] = rdr[clean];
                            }
                            row["Extra"] = extra;
                        }

                        items.Add(row);
                    }
                }
            }

            return ApiUtil.Success("Dropdown loaded", items);
        }
        catch (Exception ex)
        {
            return ApiUtil.Error("Failed to load dropdown data", ex.Message);
        }
    }



}
