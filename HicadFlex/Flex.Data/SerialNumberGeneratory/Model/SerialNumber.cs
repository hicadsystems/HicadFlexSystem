using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SerialNumberGenerator.Model
{
    public class SerialNumber
    {
        public long ID { get; set; }
        public long Serial { get; set; }
        public String ContextKey { get; set; }
        public String DateKey { get; set; }

    }
    public class SerialNumberContext : DbContext
    {
        public DbSet<SerialNumber> SerialNumber { get; set; }
    }
}
