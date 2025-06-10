using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace biomedical_pos.Api.helpers
{
    public class ApiResponse
    {
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public bool? Status { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public object Message { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Error { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public object ResponseCode { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public object Data { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public bool? RequiresReauthentication { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Dictionary<string, object> Metadata { get; set; }

        public ApiResponse() { }

        public ApiResponse(bool status, string message)
        {
            Status = status;
            Message = message;
        }

        public ApiResponse(bool status, string error, string message)
        {
            Status = status;
            Error = error;
            Message = message;
        }

        public ApiResponse(bool status, string message, object data)
        {
            Status = status;
            Message = message;
            Data = data;
        }
    }
}