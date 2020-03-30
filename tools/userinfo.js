'use strict';

// first run `npm i request`
const request = require('request');

const access_token=process.env.access_token || process.argv[2];

request.get('https://amin0.pagekite.me/auth/userinfo',
    {headers : {'authorization' : 'bearer ' + access_token}},
    (err, r, b) => {
        if (err) { return console.log(err); }
        if (r.statusCode !== 200) return new Error('StatusCode: ' + r.statusCode);
        const info = JSON.parse(b);
        console.log(JSON.stringify(info, null, '  '));
    }
);
