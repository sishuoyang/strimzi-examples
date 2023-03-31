from kafka import KafkaProducer
import random
# Define the Kafka topic and broker location
servers = ['a4d9e937ea7444100a1b84754bdf7405-1715696427.ap-southeast-1.elb.amazonaws.com:9095']

# Create a Kafka producer instance
producer = KafkaProducer(bootstrap_servers=servers)

topics = ['test-p1-r1', 'test-p1-r3',
          'test-p3-r3', 'test-p12-r3', 'test-p6-r3']
topic_weights = [0.1, 0.3, 0.2, 0.05, 0.35]
# Send 1 million messages to the Kafka topic with a message key
for j in range(10):
    print('Iteration {}'.format(j))
    for i in range(10000000):
        topic_name = random.choices(topics, topic_weights)[0]
        key_choice = random.choices(['key1', 'key2', 'key3'], weights=[
                                    0.6, 0.2, 0.2], k=1)[0]
        message_key = key_choice.encode()  # encode message key as bytes
        # encode message value as bytes
        message_value = f"MessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessageMessage {i}".encode(
        )
        producer.send(topic_name, key=message_key, value=message_value)

        # sleep for a short time to avoid overwhelming the Kafka broker
        # time.sleep(0.001)

    # Wait for any outstanding messages to be delivered and delivery reports received
    producer.flush()

# Close the Kafka producer connection
producer.close()
