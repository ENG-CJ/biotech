using biomedical_pos.Api.helpers;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for expense_api
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
 [System.Web.Script.Services.ScriptService]
public class expense_api : System.Web.Services.WebService
{

    public expense_api()
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
    public object SaveExpenseCategory(int CategoryId, string CategoryName, string Description)
    {
        ApiResponse response = new ApiResponse();
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_SaveExpenseCategory", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CategoryId", CategoryId);
                cmd.Parameters.AddWithValue("@CategoryName", CategoryName);
                cmd.Parameters.AddWithValue("@Description", Description);
           
                cmd.ExecuteNonQuery();
            }

            response = new ApiResponse(true, "Expense category saved successfully");
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to save category");
        }

        return response;
    }

    [WebMethod]
    public object GetExpenseCategories()
    {
        ApiResponse response = new ApiResponse();
        List<object> list = new List<object>();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetExpenseCategories", con))
            {
      
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        list.Add(new
                        {
                            CategoryId = rdr["CategoryId"],
                            CategoryName = rdr["CategoryName"],
                            Description = rdr["Description"],
                            CreatedAt = Convert.ToDateTime(rdr["CreatedAt"]).ToString("yyyy-MM-dd HH:mm")
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Loaded", list);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to load data");
        }

        return response;
    }


    [WebMethod]
    public object SaveExpense(int ExpenseId, int ExpenseCategoryId, decimal Amount, string Description, string ExpenseDate)
    {
        ApiResponse response = new ApiResponse();
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_SaveExpense", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ExpenseId", ExpenseId);
                cmd.Parameters.AddWithValue("@ExpenseCategoryId", ExpenseCategoryId);
                cmd.Parameters.AddWithValue("@Amount", Amount);
                cmd.Parameters.AddWithValue("@Description", Description ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@ExpenseDate", Convert.ToDateTime(ExpenseDate));
        
                cmd.ExecuteNonQuery();
            }

            response = new ApiResponse(true, "Expense saved successfully");
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Error occurred while saving");
        }

        return response;
    }

    [WebMethod]
    public object GetAllExpenses()
    {
        ApiResponse response = new ApiResponse();
        List<object> list = new List<object>();

        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("sp_GetAllExpenses", con))
            {
               
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        list.Add(new
                        {
                            ExpenseId = rdr["ExpenseId"],
                            CategoryName = rdr["CategoryName"],
                            Amount = rdr["Amount"],
                            Description = rdr["Description"],
                            category = rdr["ExpenseCategoryId"],
                            ExpenseDate = Convert.ToDateTime(rdr["ExpenseDate"]).ToString("yyyy-MM-dd")
                        });
                    }
                }
            }

            response = new ApiResponse(true, "Expenses fetched", list);
        }
        catch (Exception ex)
        {
            response = new ApiResponse(false, ex.Message, "Failed to fetch expenses");
        }

        return response;
    }

}
