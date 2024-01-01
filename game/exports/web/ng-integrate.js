var APP_ID = ''
var AES_ENCRYPTION_KEY = ''

var ngio = new Newgrounds.io.core(APP_ID, AES_ENCRYPTION_KEY);


function onLoggedIn() {
    console.log("Welcome " + ngio.user.name + "!");
    ngio.queueComponent("Medal.getList", {}, onMedalsLoaded);
    ngio.queueComponent("ScoreBoard.getBoards", {}, onScoreboardsLoaded);
    ngio.executeQueue();

}

function onLoginFailed() {
    console.log("There was a problem logging in: " . ngio.login_error.message );
}

function onLoginCancelled() {
    console.log("The user cancelled the login.");
}


function initSession() {
    ngio.getValidSession(function() {
        if (ngio.user) {
            onLoggedIn();
        } else {
            //request login;
        }

    });
}

function requestLogin() {
    ngio.requestLogin(onLoggedIn, onLoginFailed, onLoginCancelled);
    /* you should also draw a 'cancel login' buton here */
}

function initSession() {
    ngio.getValidSession(function() {
        if (ngio.user) {
            onLoggedIn();
        } else {
            requestLogin();
        }

    });
}


var medals, scoreboards;

function onScoreboardsLoaded(result) {
    console.log(result.scoreboards);
    if (result.success) scoreboards = result.scoreboards;
}

function onMedalsLoaded(result) {
    console.log(result.medals);
    if (result.success) medals = result.medals;
}

console.log(ngio);

function unlockMedal(medal_name) {

    /* If there is no user attached to our ngio object, it means the user isn't logged in and we can't unlock anything */
    if (!ngio.user) return;

    var medal;

    for (var i = 0; i < medals.length; i++) {

        medal = medals[i];

        /* look for a matching medal name */
        if (medal.name == medal_name) {

            /* we can skip unlocking a medal that's already been earned */
            if (!medal.unlocked) {

                /* unlock the medal from the server */
                ngio.callComponent('Medal.unlock', {id:medal.id}, function(result) {

                    if (result.success) 
                        onMedalUnlocked(result.medal);
                    else 
                        console.log(result);
                });
            }

            return;
        }
    }
}

function onMedalUnlocked(medal) {
    console.log(medal);
}

function postScore(board_name, score_value) {

    if (!ngio.user) return;

    for (var i = 0; i < scoreboards.length; i++) {

        scoreboard = scoreboards[i];
        if(scoreboard.name == board_name){
            ngio.callComponent('ScoreBoard.postScore', {id:scoreboard.id, value:score_value});
            console.log({board_name, score_value})
        }
    }
}