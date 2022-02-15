using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Data.Model
{
    public partial class ClaimRequest
    {
        public Nullable<Flex.Data.Enum.ClaimStatus> Status { get; set; }
    }
}
