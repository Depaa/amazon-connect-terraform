//⚠️ This is just an example, normally you need to put some logic here

exports.handler = (event) => {
  event.Records.forEach(record => {
    const buffer = Buffer.from(record.kinesis.data, 'base64');
    const data = JSON.parse(buffer);

    console.log(JSON.stringify(data))
  });
}
