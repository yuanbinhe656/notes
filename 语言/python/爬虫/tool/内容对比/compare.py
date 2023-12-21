import difflib

def compare_text(text1, text2):
    # 按行分割文本
    lines1 = text1.splitlines()
    lines2 = text2.splitlines()

        
     
    # 创建 Differ 对象
    differ = difflib.Differ()

    # 比较两个文本
    diff = list(differ.compare(lines1, lines2))

    # 打印差异
    print('\n'.join(diff))
    

if __name__ == "__main__":

    with open('./1.txt','r') as f:
        text1 = f.read()
    with open('./2.txt','r') as f:
        text2 = f.read()

    compare_text(text1, text2)
    text1 = input()
