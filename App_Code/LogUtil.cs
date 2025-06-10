using biomedical_pos.Api.helpers;
using System;
using System.Data.SqlClient;
using System.Web;

public static class LogUtil
{
    public static void WriteLog(long? userId, string action, string details, bool isSuccess)
    {
        try
        {
            using (SqlConnection con = DB.GetOpenConnection())
            using (SqlCommand cmd = new SqlCommand("InsertLog", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserID", (object)userId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Action", action);
                cmd.Parameters.AddWithValue("@Details", details);
                cmd.Parameters.AddWithValue("@IPAddress", HttpContext.Current?.Request?.UserHostAddress ?? "Unknown");
                cmd.Parameters.AddWithValue("@UserAgent", HttpContext.Current?.Request?.UserAgent ?? "Unknown");
                cmd.Parameters.AddWithValue("@IsSuccess", isSuccess);
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
            // optionally swallow or log locally to a file if DB fails
        }
    }
}
