# hoteltik

## Brief

I have recently spent a bit of time in a hotel that used MikroTik Hotspot with a password. Basically, every single time you connect to the hotspot, you need to enter password on the login page.

The problem is: this password isn't being sent as is, so this isn't just a single `curl` command to automate it. First, salt is added as both a perfix and as a postfix, then this value is converted to MD5, and only then it's added to the `POST` request. Every request to the login page generates a new salt. JS from the login page for reference:

```js
function doLogin() {
    document.sendin.username.value = document.login.password.value;
    document.sendin.password.value = hexMD5('\134' + document.login.password.value + '\017\205\055\122\043\240\041\064\304\257\213\226\265\214\121\323');
    document.sendin.submit();
    return false;
}
```

This seemed rather annoying to me, so I wasted 10 minutes automating this process (and then another 10 minutes creating this repo).

## Usage

```bash
./hoteltik.sh [-h] -u <username> <router_addr>
```
