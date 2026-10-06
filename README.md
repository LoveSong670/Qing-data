# Qing-data

X（微X 3.0）的**配置数据库**镜像。

## 布局

```
wx7/FKZ_WX_DATA           [32B SHA-256(内容)] + [SQLite 数据库]
wx7/FKZ_WX_DATA.sha256    明文 sha256，便于人工核对
```

## 文件格式

与 `Qing` 库一致 —— 每个文件是：

```
[32 字节 SHA-256(裸内容)] + [裸内容]
```

X 端校验（`x/ˈˋ/ˎٴ;->ʽʰ([B)[B`）：

```java
if (data.length < 32) return null;
byte[] hash = data[0..32];
byte[] body = data[32..];
if (!Arrays.equals(hash, MessageDigest("SHA-256").digest(body)))
    return null;          // data verification failed!
return body;
```

## 内容

| 项 | 值 |
|---|---|
| 大小 | 86016 B |
| 格式 | SQLite 3（`DATA` 表，6 列） |
| 行数 | 284 |
| TAG | 283 个 |
| ACCOUNT | `buai-qinglikai`（283 行）/ `+NO_ID+`（1 行） |

### 表结构

```sql
CREATE TABLE DATA(
    _ID     INTEGER PRIMARY KEY NOT NULL,
    ACCOUNT TEXT,
    TAG     TEXT,
    TYPE    TEXT,
    VALUE   TEXT,
    DATA    BLOB
);
```

### VALUE 加解密

```
AES-256-CBC / PKCS7，IV = 16 x 0x00
key = SHA-256("d9b2f72ea7d9c9578493fafbc913c24d")
```

## 用法

X 的配置读取：

```sql
SELECT * FROM DATA WHERE ACCOUNT = ? AND TAG = ?
```

导入方式（`wx.repair.tool` 等价）：

```
1. 拷到 /data/data/com.tencent.mm/databases/FKZ_WX_DATA
   （以及 /data/data/com.tencent.mm/files/FKZ_WX_DATA）
2. 权限 777
3. UPDATE DATA set ACCOUNT = <当前 wxid>
```

## 注意

导入后**必须补齐两个闸门字段**，否则 X 会取默认值走 native 分支：

```
type      = free      (STRING)
encrypt   = false     (BOOLEAN)
```

本库的原始文件里**这两个 TAG 不存在**。

## 闸门字段（重要）

本库**不含** `type` 与 `encrypt` 两个 TAG。X 读取配置的方式是：

```sql
SELECT * FROM DATA WHERE ACCOUNT = ? AND TAG = ?
```

查不到就走默认值 —— `encrypt` 默认为 `true`，X 会因此走 native 分支。
导入后请补齐：

| TAG | TYPE | 明文值 |
|---|---|---|
| `type` | STRING | `free` |
| `encrypt` | BOOLEAN | `false` |
| `valid` | BOOLEAN | `true` |
| `permaban` | BOOLEAN | `false` |

VALUE 用 AES-256-CBC 加密后写入：

```
key = SHA-256("d9b2f72ea7d9c9578493fafbc913c24d")
IV  = 16 x 0x00
```

## 许可

仅供本地测试与研究使用。