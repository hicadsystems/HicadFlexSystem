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
        private static SerialNumberEntities _context;
        public static SerialNumberEntities dbcontext
        {
            get
            {
                if (_context == null)
                {
                    _context = new SerialNumberEntities();
                }
                return _context;
            }
        }

    }
}
