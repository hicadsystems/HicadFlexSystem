using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Data.ViewModel
{
    public struct ProcessResult
    {
        public ProcessResult(int affectedItems, string desc) : this(affectedItems, null, desc) { }
        public ProcessResult(int affectedItems, string code, string desc, string url=null)
        {
            AffectedItems = affectedItems;
            Description = desc;
            RespCode = code;
            ResourceUrl = url;
        }
        public int AffectedItems;
        public string Description;
        public String RespCode;
        public String ResourceUrl;
    }
}
