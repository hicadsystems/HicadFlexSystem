using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Insurance.Data.ViewModel
{
    public class PagedResult<T>
    {
        public IEnumerable<T> Items { get; set; }
        public Int32 RowCount { get { return Items.Count(); } }
        public int CurrentPage { get; set; }
        public Int64 LongRowCount { get; set; }
        public dynamic Aggregates { get; private set; }
        public int PageCount { get; set; }
        public int PageSize { get; set; }
    }
}
