1. Default

    1. 在类内使用函数=defea修饰==声明==时，相当于将该函数声明为内联函数，而若不想将其声明为内联函数则应当在其类外定义时使用

    2. 只有具有合成版本的成员函数使用

        1. 默认构造函数
        2. 拷贝控制函数（五个）

    3. eg：

        ```c++
        class Sales_data
        {
        public:
        sales_data()=default；//相当于声明内联函数
        sales_data(const sales_data&);
        }
        ales_data(const sales_data&)=default//不声明其为内联函数
        {
            
        }
        ```

        