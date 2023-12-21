1. 一个类的对象可以访问该类其他对象的数据成员，相当于友元

    1. 代码：

        ```c++
        class complex
        {
        public :  
        complex(int x=0,int y=0) : re(x),im(y){ }
          int function(const complex & parm)
          {
              return parm.re+parm.im;//相当于该this对象直接访问parm对象的成员
        }
        }
        void main()
        {
            complex a1,a2(1,2);
            a1.function(a2);
        }
        ```

        