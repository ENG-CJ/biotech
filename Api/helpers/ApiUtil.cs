using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace biomedical_pos.Api.helpers
{
    public class ApiUtil
    {

        public static ApiResponse Success(string message = "Success", object data = null)
        {
            return new ApiResponse
            {
                Status = true,
                Message = message,
                Data = data
            };
        }

        public static ApiResponse Error(string message = "An error occurred", string error = null)
        {
            return new ApiResponse
            {
                Status = false,
                Message = message,
                Error = error
            };
        }
    }
}