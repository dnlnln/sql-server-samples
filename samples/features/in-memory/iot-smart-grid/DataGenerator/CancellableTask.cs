using System.Threading;
using System.Threading.Tasks;

namespace DataGenerator
{
    internal struct CancellableTask
    {
        public CancellableTask(int id, Task task, CancellationTokenSource cancellationTokenSource)
        {
            this.Id = id;
            this.Task = task;
            this.CancellationTokenSource = cancellationTokenSource;
        }

        public int Id { get; }

        public Task Task { get; }

        public CancellationTokenSource CancellationTokenSource { get; }
    }
}
