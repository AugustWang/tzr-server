 $(function() {
            jQuery.fn.alternateRowColors = function() {                      //做成插件的形式
                $('tbody tr:odd', this).removeClass('even').addClass('odd'); //隔行变色 奇数行
                $('tbody tr:even', this).removeClass('odd').addClass('even'); //隔行变色 偶数行
                return this;
            };

            $('table.myTable').each(function() {
                var $table = $(this);                       //将table存储为一个jquery对象
                $table.alternateRowColors($table);          //在排序时隔行变色

                $('th', $table).each(function(column) {
                    var findSortKey;
                    if ($(this).is('.sort-alpha')) {       //按字母排序
                        findSortKey = function($cell) {
                            return $cell.find('sort-key').text().toUpperCase() + '' + $cell.text().toUpperCase();
                        };
                    } else if ($(this).is('.sort-numeric')) {       //按数字排序
                        findSortKey = function($cell) {
                            var key = parseFloat($cell.text().replace(/^[^\d.]*/, ''));
                            return isNaN(key) ? 0 : key;
                        };
                    } else if ($(this).is('.sort-date')) {          //按日期排序
                        findSortKey = function($cell) {
                            return Date.parse('1 ' + $cell.text());
                        };
                    }

                    if (findSortKey) {
                        $(this).addClass('clickable').hover(function() { $(this).addClass('hover'); }, function() { $(this).removeClass('hover'); }).click(function() {
                            //反向排序状态声明
                            var newDirection = 1;
                            if ($(this).is('.sorted-asc')) {
                                newDirection = -1;
                            }
                            var rows = $table.find('tbody>tr').get(); //将数据行转换为数组
                            $.each(rows, function(index, row) {
                                row.sortKey = findSortKey($(row).children('td').eq(column));
                            });
                            rows.sort(function(a, b) {
                                if (a.sortKey < b.sortKey) return -newDirection;
                                if (a.sortKey > b.sortKey) return newDirection;
                                return 0;
                            });
                            $.each(rows, function(index, row) {
                                $table.children('tbody').append(row);
                                row.sortKey = null;
                            });

                            $table.find('th').removeClass('sorted-asc').removeClass('sorted-desc');
                            var $sortHead = $table.find('th').filter(':nth-child(' + (column + 1) + ')');
                            //实现反向排序
                            if (newDirection == 1) {
                                $sortHead.addClass('sorted-asc');
                            } else {
                                $sortHead.addClass('sorted-desc');
                            }

                            //调用隔行变色的函数
                            $table.alternateRowColors($table);
                            //移除已排序的列的样式,添加样式到当前列
                            $table.find('td').removeClass('sorted').filter(':nth-child(' + (column + 1) + ')').addClass('sorted');
                            $table.trigger('repaginate');
                        });
                    }
                });
            });
        });
       
   