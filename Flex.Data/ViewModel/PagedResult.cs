using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class PagedResult<T>
    {
        public IEnumerable<T> Items { get; set; }
        public Int64 RowCount { get { return Items.Count(); } }
        public long LCurrentPage { get; set; }
        public int CurrentPage { get; set; }
        public Int64 LongRowCount { get; set; }
        public dynamic Aggregates { get; private set; }
        public int PageCount { get; set; }
        public long LPageSize { get; set; }
        public int PageSize { get; set; }
    }
}
