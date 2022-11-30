using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Business
{
    public class XpressPaymentSystem : CoreSystem<OnlineReciept>
    {
        private DbContext _context;
        public XpressPaymentSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

    }
}
