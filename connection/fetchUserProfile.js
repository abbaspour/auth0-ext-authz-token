(() => {
    function fetchUserProfile(access_token, ctx, cb) {
        'use strict';
        console.log('fetchUserProfile with access_token: ' + access_token);
        // noinspection ES6ModulesDependencies
        request.get('https://amin0.pagekite.me/auth/userinfo',
            {headers: {'authorization': 'bearer ' + access_token}},
            (err, r, b) => {
                if (err) {
                    return console.log(err);
                }
                if (r.statusCode !== 200) return cb(new Error('invalid statusCode: ' + r.statusCode));
                const info = JSON.parse(b);
                console.log('fetchUserProfile userInfo: ' + JSON.stringify(info, null, '  '));
                // noinspection JSUnresolvedVariable
                let profile = {user_id: info.name};
                return cb(null, profile);
            }
        )
    }

    // noinspection JSUnresolvedVariable
    if (module) { // noinspection JSUnresolvedVariable
        module.exports = fetchUserProfile;
    }

    return fetchUserProfile;
})()
