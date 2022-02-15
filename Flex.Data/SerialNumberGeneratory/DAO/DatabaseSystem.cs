using SerialNumberGenerator.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SerialNumberGenerator.DAO
{
    public static class DatabaseSystem
    {
        private static SerialNumberContext _context;
        public static SerialNumberContext dbcontext
        {
            get
            {
                if (_context == null)
                {
                    _context = new SerialNumberContext();
                }
                return _context;
            }
        }

    }
}
