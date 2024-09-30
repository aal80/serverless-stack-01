export const handler = async (event)=>{
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/plain'
    },
    body: "Hey there re:Invent 2024!",
  }
}
