const currentJobLogsEle = document.getElementById("current-job-logs");
if (currentJobLogsEle && currentJobLogsEle.innerText.trim().length > 0) {
    setInterval(async () => {
    currentJobLogsEle.innerText = await (await fetch("logs/current")).text();
    }, 700);
}
