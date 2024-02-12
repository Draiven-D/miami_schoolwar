const vue = new Vue({
    el: '#ui',
    data: {
        ShowUI: false,
        teamData: [],
        FeedDatas: [],
		ShowProp: false,
        PropData: [],
    },
    methods: {
        addFeed(feedData) {
			this.FeedDatas.splice(this.FeedDatas.length, 0, feedData);
			setTimeout(()=>{
				this.FeedDatas.splice(0, 1)	
			}, 4000); 
		},
    }
});

window.addEventListener('message', function (event) {
	var event = event.data;

	if (event.message == "openUI") {
		vue.ShowUI = true;
        vue.teamData = event.teamData;
		vue.PropData = event.propData;
	} else if (event.message == "hideUI") {
		vue.ShowUI = false;
	} else if (event.message == "updateData") {
        vue.teamData = event.teamData;
	} else if (event.message == 'updateFeed') {
		vue.addFeed(event.sendData);
	} else if (event.message == "UpdateHP") {
		vue.PropData = event.propData;
	}
});