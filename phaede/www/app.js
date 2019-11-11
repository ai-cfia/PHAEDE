jQuery(document).ready(function() {
	console.log(window.jQuery);
	let listURL = [];
	let listTitle = [];
	let listDescription = [];
	let listTitleDescription = [];
	let url1 = "https://www.alibaba.com/products/";
	let url2 = ".html?IndexArea=product_en&page=";
	let proxy = "https://cryptic-fortress-93226.herokuapp.com/";

	$("#search").click(function() {
		let term = $("#term").val().split(" ").join("_");
		let pageNum = 1;
		listURL = [];
		listTitle = [];
		listDescription = [];
		listTitleDescription = [];
		overlayOn();
		getItemsInPage(term, pageNum);
	})

	$(document).ajaxStop(function() {
		overlayOff();
		Shiny.onInputChange("list_url", listURL);
		console.log(listURL);
		Shiny.onInputChange("list_title", listTitle);
		console.log(listTitle);
		Shiny.onInputChange("list_description", listDescription);
		console.log(listDescription);
		Shiny.onInputChange("list_title_description", listTitleDescription);
		console.log(listTitleDescription);
	});

	function getItemsInPage(term, pageNum) {
		let itemNum = 0;
		$.ajax({
			url: proxy + url1 + term + url2 + pageNum,
			method: "GET",
			async: true,
			success: function(data) {
				let page = $(data);
				page.find("div.item-content").each(function(i, obj) {
					let itemURL = $(obj).find("a").attr("href");
					getItemDetailFromURL(itemURL);
					itemNum++;
				})
			},
			complete: function() {
				if(itemNum > 0) {
					pageNum++;
					getItemsInPage(term, pageNum);
				}
			}
		})
	}

	function getItemDetailFromURL(itemURL) {
		$.ajax({
			url: proxy + itemURL,
			method: "GET",
			async: true,
			success: function(data) {
				listURL.push(itemURL);
				let page = $(data);
				let title = page.find("h1.ma-title").text().trim();
				listTitle.push(title);
				let description = page.find("div.richtext.richtext-detail.rich-text-description").html();
				if(description) {
					description = description.replace(/(<([^>]+)>)/ig, " ")
											 .replace(/.*\..*\{(.*)\}/ig, " ")
											 .replace(/&nbsp;/ig, " ")
											 .replace(/&amp;/ig, "&")
											 .replace(/&quot;/ig, "\"")
											 .replace(/&lt;/ig, "<")
											 .replace(/&gt;/ig, ">")
											 .replace(/\s\s+/ig, " ")
											 .trim();
				} else {
					description = "";
				}
				listDescription.push(description);
				let titleDescription = title + " " + description;
				listTitleDescription.push(titleDescription);
			}
		})
	}

	function overlayOn() {
		$("#overlay").show();
	}

	function overlayOff() {
		$("#overlay").hide();
	}
});